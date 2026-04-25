package com.vetautet.ddd.controller.resource;

import com.vetautet.ddd.application.service.ticket.ITicketDetailAppService;
import com.vetautet.ddd.controller.model.enums.ResultUtil;
import com.vetautet.ddd.controller.model.vo.ResultMessage;
import com.vetautet.ddd.domain.model.entity.TicketDetail;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ticket")
@Slf4j
@Tag(name = "Ticket", description = "Ticket Detail APIs")
public class TicketDetailController {

    @Autowired
    private ITicketDetailAppService ticketDetailAppService;

    @GetMapping("/{ticketId}/detail/{detailId}")
    @Operation(summary = "Get ticket detail", description = "Get ticket detail by ticketId and detailId")
    public ResultMessage<TicketDetail> getTicketDetail(
            @PathVariable("ticketId") Long ticketId,
            @PathVariable("detailId") Long detailId
    ) {
        log.info("GET ticket detail — ticketId:{}, detailId:{}", ticketId, detailId);
        return ResultUtil.data(ticketDetailAppService.getTicketDetailById(detailId));
    }
}